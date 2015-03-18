From: Kamal Mostafa <kamal@canonical.com>
Subject: Re: [PATCH][3.13.y-ckt][PATCH 0/1] Backport of mainline commit
 4a46b24e for upstream 3.13.y-ckt.
Date: Wed, 18 Mar 2015 16:17:57 -0700
Message-ID: <1426720677.8485.90.camel@fourier>
References: <cover.1424801573.git.joseph.salisbury@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: alexw@nicira.com, azhou@nicira.com, pshelar@nicira.com,
	davem@davemloft.net, netdev@vger.kernel.org, dev@openvswitch.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
To: Joseph Salisbury <joseph.salisbury@canonical.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <cover.1424801573.git.joseph.salisbury@canonical.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-02-27 at 15:19 -0500, Joseph Salisbury wrote:
> A large number of 'failed to flow_del' error messages are being logged
> in OpenStack deployments running the Ubuntu Trusty release with the
> 3.13 kernel. This was fixed upstream in the datapath dkms module as
> well as the 3.16 kernel.  
> 
> Commit 4a46b24e is the fix for this issue, and is in mainline as of
> 3.16-rc6.  However, commit 4a46b24e has a dependency on commit
> 663efa36 for the define of rcu_dereference_ovsl.
> 
> Commit 663efa36 is a clean cherry-pick in upstream 3.13.y-ckt.
> However, 4a46b24e required a backport.  Please consider including
> mainline commit 663efa36 and the backported version of 4a46b24e in the
> next v3.13.y-ckt release.
> 
> The backport for upstream stable 3.14.y is different than for
> 3.13.y-ckt and I'm not sure if this bug exists in upstream 3.14.  I
> can send that backport separately if needed.
> 

I have queued these for 3.13-stable:

4a46b24* openvswitch: Use exact lookup for flow_get and flow_del.
663efa3  openvswitch: Silence RCU lockdep checks from flow lookup.

*(your backport of)

Thanks Joseph,

 -Kamal
