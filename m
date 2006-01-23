From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [BUG] sky2 broken for Yukon PCI-E Gigabit Ethernet Controller
 11ab:4362 (rev 19)
Date: Mon, 23 Jan 2006 10:15:38 -0800
Message-ID: <20060123101538.14d21bf4@dxpl.pdx.osdl.net>
References: <43D1C99E.2000506@t-online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964832AbWAWSPs@vger.kernel.org>
To: Knut Petersen <Knut_Petersen@t-online.de>
In-Reply-To: <43D1C99E.2000506@t-online.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

O
> 
> It seems that the SuSE Firewall locked something ....
> 
> I started with kernel 2.6.15-git7, tried 2.6.15.1 and 2.6.16-rc1*.
> At the moment I do use a kernel 2.6.15-git7 patched with an updated sky2 
> (v.013).
> I could not find a single working sky2 configuration.
> 

Are you using the full kernel.org kernel, or are you putting sky2 driver into
the SUSE kernel? There are a number of bug fixes related to hardware checksumming
that are in the kernel.org kernel (2.6.15 or later).  There was one in ICMP.
These fixes relate to places in the code where a protocol decides to trim a
packet by removing bytes. I am not familiar with the SuSE Firewall. Is it just
standard netfilter modules or additional code?

-- 
Stephen Hemminger <shemminger@osdl.org>
OSDL http://developer.osdl.org/~shemminger
