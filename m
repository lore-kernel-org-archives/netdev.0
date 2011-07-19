From: Mimi Zohar <zohar@linux.vnet.ibm.com>
Subject: Re: [PATCH] Add error check to hex2bin().
Date: Tue, 19 Jul 2011 06:52:46 -0400
Message-ID: <1311072766.3258.8.camel@localhost.localdomain>
References: <1310977597-9666-1-git-send-email-andriy.shevchenko@linux.intel.com>
	 <201107182041.EHB78622.VOFSHFMOOFtLJQ@I-love.SAKURA.ne.jp>
	 <1310991796.3903.6.camel@smile>
	 <201107182148.AGD21306.FOLtJVMSOOFQHF@I-love.SAKURA.ne.jp>
	 <CAMuHMdVxR7AC7H_Yys8SiaGqM2JsNXLsRpujqojMYd_CXWxcAw@mail.gmail.com>
	 <CAHp75VdTiMtmXdVSMq=6bAH2+rmSBHPPE9hQOLQN+Y3qPBEVFg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	linux-security-module@vger.kernel.org,
	andriy.shevchenko@linux.intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andy Shevchenko <andy.shevchenko@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHp75VdTiMtmXdVSMq=6bAH2+rmSBHPPE9hQOLQN+Y3qPBEVFg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(sorry for re-posting, but this doesn't seem to have made it to the
lists.)

On Tue, 2011-07-19 at 00:18 +0300, Andy Shevchenko wrote:
> On Mon, Jul 18, 2011 at 11:49 PM, Geert Uytterhoeven
> <geert@linux-m68k.org> wrote:
> > What about making it return the number of unprocessed bytes left instead?
> > Then the caller knows where the problem lies. And zero would mean success.
> If I remember correctly it used to be src as return value in some
> version of that patch. I don't know the details of that interim
> solution. My current opinion is to return boolean and make an
> additional parameter to return src value. However, it could make this
> simple function fat.
> P.S. Take into account that the user of it is only one so far, I would
> like to hear a Mimi's opinion.
> 

Trusted/encrypted keys are not in a critical code path. They're used for
loading/storing key blobs from userspace.  From a trusted/encrypted key
perspective, it doesn't make much of a difference.

thanks,

Mimi
