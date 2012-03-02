From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/4] Netfilter: Merge ipt_LOG and ip6_LOG into xt_LOG
Date: Fri, 2 Mar 2012 17:49:45 +0100
Message-ID: <20120302164945.GA13723@1984>
References: <1328400892-22409-1-git-send-email-richard@nod.at>
 <1328400892-22409-3-git-send-email-richard@nod.at>
 <20120301112732.GA6806@1984>
 <4F4FEC83.6090504@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, eric.dumazet@gmail.com,
	jengelh@medozas.de, rostedt@goodmis.org
To: Richard Weinberger <richard@nod.at>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4F4FEC83.6090504@nod.at>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 01, 2012 at 10:39:15PM +0100, Richard Weinberger wrote:
> Am 01.03.2012 12:27, schrieb Pablo Neira Ayuso:
> > While merging ipt_LOG and ip6t_LOG, you introduced some bug that
> > corrupts the log line. Note the extra PROTO=, I don't have any UDPLITE
> > traffic here.
> > 
> > Looks like a missing break in one switch.
> 
> I got confused by my own logic. :-\
> Does the attached patch fix the issue?
> It's based on "Netfilter: xt_LOG: Add timestamp support"

This patch lacks of description. If you don't make it myself, I have
to do it for you :-(

Please, send me patches following the standard format next time.
