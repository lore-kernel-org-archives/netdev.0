From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH] Add error check to hex2bin().
Date: Mon, 18 Jul 2011 22:44:29 +0300
Message-ID: <CAHp75VeQSSoW6u-LGdhoNf_mh7WP5076bpzygf710Ro8aj1+Cg@mail.gmail.com>
References: <1310977597-9666-1-git-send-email-andriy.shevchenko@linux.intel.com>
	<201107182041.EHB78622.VOFSHFMOOFtLJQ@I-love.SAKURA.ne.jp>
	<1310991796.3903.6.camel@smile>
	<201107182148.AGD21306.FOLtJVMSOOFQHF@I-love.SAKURA.ne.jp>
	<1311012230.3193.35.camel@localhost.localdomain>
	<CAHp75VcXNQKej_n4cOB8-gYDSL8MuGrv=Fs8=zdEKGp53DCtSA@mail.gmail.com>
	<1311016856.3648.15.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	linux-security-module@vger.kernel.org,
	andriy.shevchenko@linux.intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Mimi Zohar <zohar@linux.vnet.ibm.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1311016856.3648.15.camel@localhost.localdomain>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 18, 2011 at 10:20 PM, Mimi Zohar <zohar@linux.vnet.ibm.com>=
 wrote:

>> > We probably don't need to define a separate 'safe' function.
>> There is an opponent on any =C2=A0approach. Although, small and fast=
 error
>> route could be good.

> As nothing but trusted/encrypted keys is using hex2bin, it shouldn't =
be
> a problem. =C2=A0:-)
The key word "until now". But people will start to use anything which
has public API, won't they?

> =C2=A0I'll update trusted/encrypted keys to check the return
> code.
Actually another question shall we add __must_check to the prototype or=
 not?

--=20
With Best Regards,
Andy Shevchenko
--
To unsubscribe from this list: send the line "unsubscribe linux-securit=
y-module" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
