From: "=?UTF-8?Q?Rui_Tiago_Ca=C3=A7=C3=A3o_Matos?=" <rmatos@av.it.pt>
Subject: Re: [PATCH] Remove usage of C++ keyword 'class' on htb.h header.
Date: Wed, 5 Mar 2008 14:41:19 +0000
Message-ID: <eae3b3410803050641n6b45cd7ei53f18b59832ba919@mail.gmail.com>
References: <1204655476-2663-1-git-send-email-rmatos@av.it.pt>
	 <1204655476-2663-2-git-send-email-rmatos@av.it.pt>
	 <20080305124220.GH20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Thomas Graf" <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:25301 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750802AbYCEOlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 09:41:21 -0500
Received: by ug-out-1314.google.com with SMTP id z38so3304545ugc.16
        for <netdev@vger.kernel.org>; Wed, 05 Mar 2008 06:41:19 -0800 (PST)
In-Reply-To: <20080305124220.GH20815@postel.suug.ch>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/03/2008, Thomas Graf <tgraf@suug.ch> wrote:
>  Is this the only change required to make all the headers c++ safe?

I'm quite sure there are no more headers using the 'class' keyword. As
I find more problems I'll keep you posted. A simple .cpp file
including all of the netlink/ headers fails to compile with messages
like

'__u32' does not name a type

I suppose there are implicit header dependencies but I'm not familiar
enough with libnl yet to say.

BTW, there isn't a catch all header in libnl, is there?

Rui
