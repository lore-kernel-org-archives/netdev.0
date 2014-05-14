From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 0/5] bonding: simple macro cleanup
Date: Wed, 14 May 2014 09:29:43 -0700
Message-ID: <1400084983.19788.15.camel@joe-AO725>
References: <1400072064-26095-1-git-send-email-vfalico@gmail.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1724466A@AcuExch.aculab.com>
	 <20140514132922.GA24104@mikrodark.usersys.redhat.com>
	 <CAADnVQKw3npBoeuQbVf4FtDiqiZuc7+1z7fwUL_6Vru-p3BwDQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Veaceslav Falico <vfalico@gmail.com>,
	David Laight <David.Laight@aculab.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@redhat.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0118.hostedemail.com ([216.40.44.118]:38023 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753279AbaENQ3t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 12:29:49 -0400
In-Reply-To: <CAADnVQKw3npBoeuQbVf4FtDiqiZuc7+1z7fwUL_6Vru-p3BwDQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-05-14 at 09:10 -0700, Alexei Starovoitov wrote:
> from compiler point of view it's actually easier to deal with inline functions
> than macros. I'd suggest to do the full conversion the other way around:
> convert all macros to static inline. Developers will enjoy better type safety
> and compiler will enjoy more opportunities to optimize code.

Agree about the type safety, but sometimes a compiler will
generate worse code with static inlines than #defines.
