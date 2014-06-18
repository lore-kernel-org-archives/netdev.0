From: Sergey Ryazanov <ryazanov.s.a@gmail.com>
Subject: Re: [PATCH 09/28] Remove ATHEROS_AR231X
Date: Wed, 18 Jun 2014 15:10:02 +0400
Message-ID: <CAHNKnsSfaT7xC5_wv=TrGLEQ2pjC91Q1XG891_n64OuR0fA9Jg@mail.gmail.com>
References: <1391971686-9517-1-git-send-email-richard@nod.at>
 <1391971686-9517-10-git-send-email-richard@nod.at>
 <52F7D480.1050106@hauke-m.de> <52F7DF21.70207@nod.at>
 <CAHNKnsS7Mv4ZhBWZa53go9L9nZimJ7_FG5HFJ9C3kkGMAEz-mA@mail.gmail.com>
 <52F8C373.9060108@rempel-privat.de>
 <CAHNKnsQF5Hdf3JT91moPraRQzn4kMpdD2NSiJ7b30wQhS1W4MA@mail.gmail.com>
 <CAGVrzcYnECx5Q=i+m6qZn29y4JALDpw5SWoUNP-S6HgPR3_ygQ@mail.gmail.com>
 <CAHNKnsRACSo=DfOyiHxqV3acv_wfZmz4tMnYAW0wo4OCibwdfA@mail.gmail.com>
 <CAHNKnsRQp7WLSJNAXEYPTd=qs1DquOfNgKtHES-Utvcy1=FEgQ@mail.gmail.com>
 <20140213201421.GJ22203@tuxdriver.com> <1397581703.8212.5.camel@x220>
 <CAHNKnsQQ42-XnXrubHAy4PF3H2ynbGDdSMP7MvDS_1aRozYF=A@mail.gmail.com>
 <1403087119.1984.93.camel@x220>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: OpenWrt Development List <openwrt-devel@lists.openwrt.org>,
 Jiri Slaby <jirislaby@gmail.com>, open@hauke-m.de,
 Richard Weinberger <richard@nod.at>, ath5k-devel@venema.h4ckr.net,
 "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
 "John W. Linville" <linville@tuxdriver.com>,
 Oleksij Rempel <linux@rempel-privat.de>,
 "list@hauke-m.de:NETWORKING DRIVERS" <netdev@vger.kernel.org>,
 Nick Kossifidis <mickflemm@gmail.com>, Hauke Mehrtens <hauke@hauke-m.de>,
 "list@hauke-m.de:NETWORKING DRIVERS" <list@hauke-m.de>,
 open list <linux-kernel@vger.kernel.org>,
 "antonynpavlov@gmail.com" <antonynpavlov@gmail.com>
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <openwrt-devel-bounces@lists.openwrt.org>
In-Reply-To: <1403087119.1984.93.camel@x220>
List-Unsubscribe: <https://lists.openwrt.org/cgi-bin/mailman/options/openwrt-devel>,
 <mailto:openwrt-devel-request@lists.openwrt.org?subject=unsubscribe>
List-Archive: <http://lists.openwrt.org/pipermail/openwrt-devel/>
List-Post: <mailto:openwrt-devel@lists.openwrt.org>
List-Help: <mailto:openwrt-devel-request@lists.openwrt.org?subject=help>
List-Subscribe: <https://lists.openwrt.org/cgi-bin/mailman/listinfo/openwrt-devel>,
 <mailto:openwrt-devel-request@lists.openwrt.org?subject=subscribe>
Errors-To: openwrt-devel-bounces@lists.openwrt.org
Sender: "openwrt-devel" <openwrt-devel-bounces@lists.openwrt.org>
List-Id: netdev.vger.kernel.org

Hi Paul,

2014-06-18 14:25 GMT+04:00 Paul Bolle <pebolle@tiscali.nl>:
> Jiri, Nick, Luis, John,
>
> On Wed, 2014-04-16 at 13:20 +0400, Sergey Ryazanov wrote:
>> 2014-04-15 21:08 GMT+04:00 Paul Bolle <pebolle@tiscali.nl>:
>> > On Thu, 2014-02-13 at 15:14 -0500, John W. Linville wrote:
>> >> On Wed, Feb 12, 2014 at 02:50:30PM +0400, Sergey Ryazanov wrote:
>> >> > John, can you delay the merging of this patch for a few months, I will
>> >> > try to prepare the necessary patches to add AR231x architecture to the
>> >> > kernel and send them to linux-mips.
>> >>
>> >> OK -- looking forward to your patches.
>> >
>> > So am I. Is there any news on this front?
>> >
>>
>> Work still in progress :(
>
> ATHEROS_AR231X and the things depending on it, like AHB bus support,
> have been discussed for three years now. When will you (re)consider a
> patch to remove all currently dead code?
>
> And to state the obvious: AHB bus support, and the other code depending
> on ATHEROS_AR231X, can always be re-added once ATHEROS_AR231X gets added
> to the tree.
>

Work in progress, I don't stop it. Just work is progressing slower
than I had planned. I am already cleanup the code (mostly checkpatch
errors and warnings) and send patches to OpenWRT tree. Further I plan
to simplify initialization and I will be ready to send patches
upstream.

I need a couple of weeks for this. Is its reasonable time to not make
a mess of remove/add commits?

-- 
BR,
Sergey
