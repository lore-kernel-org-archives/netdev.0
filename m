From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: 2.6.23-rc4-mm1: e1000e napi lockup
Date: Mon, 10 Sep 2007 08:24:05 +0200
Message-ID: <46E4E305.6010406@gmail.com>
References: <46E0FB82.2040000@gmail.com> <46E3C3B9.4010500@gmail.com> <46E478BE.2030202@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net,
	"David S. Miller" <davem@davemloft.net>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:40994 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753159AbXIJGYJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2007 02:24:09 -0400
Received: by nf-out-0910.google.com with SMTP id f5so725683nfh
        for <netdev@vger.kernel.org>; Sun, 09 Sep 2007 23:24:08 -0700 (PDT)
In-Reply-To: <46E478BE.2030202@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke napsal(a):
> Jiri Slaby wrote:
>> I still have problems with the driver. When I do `ip link set eth0
>> up', ksoftirq
>> runs with 100 % cpu time, so I think you endlessly re-schedule some
>> timer (or
>> the new napi layer?)
> 
> something changed in the logic and e1000e apparently does something
> wrong. I'll look into it on monday and resubmit a fixup patch (see
> robert olsson's mail as well discussing this issue)

he's posted me a patch, but no change on my side :(.

Anyway, I'm going away of the box on monday (today). will be back on fri to
test patches :).

thanks,
-- 
http://www.fi.muni.cz/~xslaby/            Jiri Slaby
faculty of informatics, masaryk university, brno, cz
