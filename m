From: "Andrew Paprocki" <andrew@ishiboo.com>
Subject: Re: r8169 in 2.6.18 silently corrupting data, 2.6.22-rc3 link not detected at all
Date: Mon, 4 Jun 2007 20:06:30 -0400
Message-ID: <76366b180706041706i6f35c0e3w4b882acd9dc61988@mail.gmail.com>
References: <76366b180705281110j472671a1h6ff5ed5fa711c45e@mail.gmail.com>
	 <20070528195422.GA4927@electric-eye.fr.zoreil.com>
	 <76366b180705281406j69d08bbeu77ff18991f161df8@mail.gmail.com>
	 <20070528213425.GB4494@electric-eye.fr.zoreil.com>
	 <20070604210959.GA30864@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brad@langhorst.com
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.238]:12568 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760419AbXFEAGc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2007 20:06:32 -0400
Received: by nz-out-0506.google.com with SMTP id n1so1196123nzf
        for <netdev@vger.kernel.org>; Mon, 04 Jun 2007 17:06:31 -0700 (PDT)
In-Reply-To: <20070604210959.GA30864@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois,

Using the latest patch you provided in the previous e-mail under
2.6.22-rc3 I still see data corruption after I dropped the entire
network to MTU 1500. (The receive corruption is way more frequent than
under 2.6.18.) I'll attempt to find out what caused the link detection
to stop working. Do you have any idea about the data corruption? I can
easily put in trace anywhere in the driver if you'd like to see any
output. My latest build was without NAPI support, and running with or
without it didn't seem to affect the receive corruption.

Thanks, -Andrew

On 6/4/07, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Francois Romieu <romieu@fr.zoreil.com> :
> [...]
>
> Andrew, have you had any time to do some testing with an uniform 7200
> bytes MTU through your LAN ?
>
> You will find a backport of the r8169 driver for the 2.6.18 kernel at
> http://www.fr.zoreil.com/people/francois/backport/r8169/20070604-00
>
> Could you do a binary search of the patch which breaks the link detection ?
> From a different report that I have received, the current testing branch of
> the 8169 driver would improve things for MTU beyond 1500 bytes: nailing down
> your broken link regression would be a welcome improvement.
>
> If you are confortable with git, you can do a git bisect after pulling
> the branch 'r8169-backport-test-20070604' at:
> git://electric-eye.fr.zoreil.com/home/romieu/linux/linux-2.6-out
>
> (please do the initial clone from elsewhere if you use git, thanks)
>
> --
> Ueimor
>
>
