From: Stefano Brivio <sbrivio@redhat.com>
Subject: Re: [PATCH] net/i40e: use cpumask_copy() for assigning cpumask
Date: Wed, 16 Aug 2017 11:52:33 +0200
Message-ID: <20170816115233.6cc33078@elisabeth>
References: <20170812160946.2278-1-jgross@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
        stable@vger.kernel.org
To: Juergen Gross <jgross@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170812160946.2278-1-jgross@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Juergen,

On Sat, 12 Aug 2017 18:09:46 +0200
Juergen Gross <jgross@suse.com> wrote:

> Using direct assignment for a cpumask is wrong, cpumask_copy() should
> be used instead.

Perhaps a Fixes: tag might be helpful here, such as:

	Fixes: 96db776a3682 ("i40e/i40evf: fix interrupt affinity bug")

as I reported in my other (late) patch:

	http://marc.info/?l=linux-netdev&m=150279303222066&w=2

> Cc: stable@vger.kernel.org

and maybe also an indication about which versions this applies to, such as

Cc: stable@vger.kernel.org # 4.10+

In general, feel free to copy from my commit message.

These comments also apply to:

	[PATCH] net/i40evf: use cpumask_copy() for assigning cpumask

Thanks,


--
Stefano
