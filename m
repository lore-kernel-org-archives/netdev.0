From: Paul Moore <pmoore@redhat.com>
Subject: Re: [RFC PATCH v3 0/2] Fix some multiqueue TUN problems
Date: Wed, 19 Dec 2012 11:59:49 -0500
Message-ID: <2198139.EQv1ADVakk@sifl>
References: <20121218225001.16104.34454.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, jasowang@redhat.com, mst@redhat.com
To: linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov,
	eparis@redhat.com
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20121218225001.16104.34454.stgit@localhost>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday, December 18, 2012 05:53:37 PM Paul Moore wrote:
> A refresh/respin of the LSM/SELinux fixes to work on top of Jason's
> latest API tweak (now living in DaveM's net tree).  In general, I
> believe the hooks and thinking behind the v2 patchset still make sense
> so no changes there, although I did change the SELinux permission from
> "create_queue" to "attach_queue" to match the API changes.
> 
> Comments are welcome and encouraged; we need to get this fixed before
> 3.8 is released.

SELinux (I'm looking at you Eric) and LSM folks - any comments/objections to 
these changes?

> ---
> 
> Paul Moore (2):
>       selinux: add the "attach_queue" permission to the "tun_socket" class
>       tun: fix LSM/SELinux labeling of tun/tap devices

-- 
paul moore
security and virtualization @ redhat

