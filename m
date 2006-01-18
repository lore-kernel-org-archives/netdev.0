From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: wireless: the contenders
Date: Wed, 18 Jan 2006 15:36:59 -0500
Message-ID: <43CEA6EB.6080209@pobox.com>
References: <20060118200616.GC6583@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jbenc@suse.cz, softmac-dev@sipsolutions.net,
	bcm43xx-dev@lists.berlios.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030425AbWARUhM@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060118200616.GC6583@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> First, the news everyone will like.  Thanks to the kernel.org team
> I now have a place to publish a wireless tree:
> 
>    git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git
> 
> The tree there has a number of branches, so many that you need
> a scorecard...
> 
> Branches
> --------
> 
> The "master" branch of that tree is (mostly) up-to-date w/ Linus, plus
> changes I recently sent to Jeff.  Those changes are also available on
> the "upstream-jgarzik" branch, but it is frozen to when I requested
> Jeff's pull.

Minor git administrative note...  In my trees, the 'master' branch is 
always vanilla Linus, and I never ever apply my own changes to it.  This 
enables commands such as

	git diff master..upstream > patch
	git log master..upstream > log.txt
	git log master..upstream | git shortlog > shortlog.txt

to work as expected.

Typically I do not update 'master' unless I am also updating 'upstream' 
with vanilla Linus changes, in order to avoid screwing up the tree heads 
and the diff.  When I do update 'master' from 'upstream', it is a 
trivial matter to then pull those changes into 'upstream':

	git checkout -f upstream
	git pull . master

Regards,

	Jeff
