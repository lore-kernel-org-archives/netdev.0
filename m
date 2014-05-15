From: Veaceslav Falico <vfalico@gmail.com>
Subject: Re: [PATCH net-next 0/5] bonding: simple macro cleanup
Date: Thu, 15 May 2014 08:34:22 +0200
Message-ID: <20140515063422.GB27773@mikrodark.usersys.redhat.com>
References: <1400072064-26095-1-git-send-email-vfalico@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D1724466A@AcuExch.aculab.com>
 <20140514132922.GA24104@mikrodark.usersys.redhat.com>
 <CAADnVQKw3npBoeuQbVf4FtDiqiZuc7+1z7fwUL_6Vru-p3BwDQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: David Laight <David.Laight@aculab.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@redhat.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f172.google.com ([74.125.82.172]:43184 "EHLO
	mail-we0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752390AbaEOGep (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 02:34:45 -0400
Received: by mail-we0-f172.google.com with SMTP id k48so584508wev.31
        for <netdev@vger.kernel.org>; Wed, 14 May 2014 23:34:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAADnVQKw3npBoeuQbVf4FtDiqiZuc7+1z7fwUL_6Vru-p3BwDQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 14, 2014 at 09:10:33AM -0700, Alexei Starovoitov wrote:
>from compiler point of view it's actually easier to deal with inline functions
>than macros. I'd suggest to do the full conversion the other way around:
>convert all macros to static inline. Developers will enjoy better type safety
>and compiler will enjoy more opportunities to optimize code.

Ok, will move everything into inline functions.

Thanks for an interesting discussion :)
