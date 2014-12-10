From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 0/2] lib names: Refactoring and cleanups
Date: Wed, 10 Dec 2014 15:46:52 -0800
Message-ID: <20141210154652.60828ea4@urahara>
References: <1417831512-19452-1-git-send-email-vadim4j@gmail.com>
	<20141209203856.491322c0@urahara>
	<20141210151029.GA18451@angus-think.wlc.globallogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vadim4j@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:65363 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758073AbaLJXrD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 18:47:03 -0500
Received: by mail-pd0-f179.google.com with SMTP id fp1so3720856pdb.24
        for <netdev@vger.kernel.org>; Wed, 10 Dec 2014 15:47:02 -0800 (PST)
In-Reply-To: <20141210151029.GA18451@angus-think.wlc.globallogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 10 Dec 2014 17:10:29 +0200
vadim4j@gmail.com wrote:

> On Tue, Dec 09, 2014 at 08:38:56PM -0800, Stephen Hemminger wrote:
> > On Sat,  6 Dec 2014 04:05:10 +0200
> > Vadim Kochan <vadim4j@gmail.com> wrote:
> > 
> > > Some cleanups and refactoring in lib/rt_names.c:
> > > 
> > >     #1 Replaced using of /etc/iproute2 path by CONFDIR define
> > >         when initializing tables of group names.
> > > 
> > >     #2 Added helper to have one func for parsing id and names from
> > >         db files.
> > > 
> > > Vadim Kochan (2):
> > >   lib names: Use CONFDIR for specify 'group' file path
> > >   lib names: Add helper func for parse id and name from file
> > > 
> > >  lib/rt_names.c | 70 +++++++++++++++++++++++++++++++++-------------------------
> > >  1 file changed, 40 insertions(+), 30 deletions(-)
> > > 
> > 
> > Both applied
> 
> Hi Stephen,
> 
> I see a warning (after 'make clean && make') about using 'const' in lib/rt_names.c:
> 
>     static const char * rtnl_rtscope_tab[256] = {
>             "global",
>     };
> 
> which came with PATCH with a subject:
> 
>     "lib names: Add helper func for parse id and name from file" (f00073e8b)
> 
> but in the PATCH version which was sent by me in email I did not see this.
> 
> Why it was needed ?
> 
> Regards,
> Vadim

My gaff. Fixed but not pushed, holding of until include snafu is fixed
