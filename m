From: Okash Khawaja <okash.khawaja@gmail.com>
Subject: Re: [PATCH] adm8211: fix the possible pci cache line sizes inside
 switch-case
Date: Tue, 5 May 2015 23:50:22 +0100
Message-ID: <20150505225022.GA3877@bytefire-computer>
References: <20150505214851.GA3013@bytefire-computer>
 <1430863313.9365.49.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvalo@codeaurora.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1430863313.9365.49.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 05, 2015 at 03:01:53PM -0700, Joe Perches wrote:
> On Tue, 2015-05-05 at 22:48 +0100, Okash Khawaja wrote:
> > The PCI cache line size value, stored in cline variable, was being
> > compared against decimal values written as hex literals. This patch
> > changes those literals to correct hex values. 
> 
> This is fine.
> 
> The grammar might be better as something like:
> 
> The PCI cache line size value was being compared against
> decimal values prefixed with 0x.
> 
> Fix the literals to use the correct hex values. 
> 
> > Please note that this patch is on top of
> > another code cleanup patch '[PATCH] adm8211: fix checkpatch errors for
> > indentation and new line around switch-case'.
> 
> But this information doesn't belong here as
> it would also be in a git log when someone
> uses git am to apply it to a tree.
> 
> It'd be better to send a patch series using
> "git format-email --cover-letter -2 -o <dir>"
> and use git send-email for the series.
> 
> 
This is my first time going throug the process of submitting patches, something you may have already noticed. I have created and submitted patch series.Thanks
