From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [ath5k-devel] [PATCH 09/28] Remove ATHEROS_AR231X
Date: Wed, 18 Jun 2014 15:42:57 +0200
Message-ID: <1403098977.1984.111.camel@x220>
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
	 <CAHNKnsSfaT7xC5_wv=TrGLEQ2pjC91Q1XG891_n64OuR0fA9Jg@mail.gmail.com>
	 <1403091974.1984.102.camel@x220>
	 <CAOpc7mE+829tBdy5atjtoJnGWDAnAHT_U0swXCuS3n_DMave1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sergey Ryazanov <ryazanov.s.a@gmail.com>,
	List <openwrt-devel@lists.openwrt.org>,
	open list <linux-kernel@vger.kernel.org>,
	Jiri Slaby <jirislaby@gmail.com>, Richard@venema.h4ckr.net,
	"Luis R. Rodriguez" <mcgrof@do-not-panic.com>, open@hauke-m.de,
	Weinberger <richard@nod.at>, ath5k-devel@venema.h4ckr.net,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Oleksij Rempel <linux@rempel-privat.de>,
	Hauke@venema.h4ckr.net, Mehrtens <hauke@hauke-m.de>,
	"list@hauke-m.de:NETWORKING DRIVERS" <list@hauke-m.de>,
	Jonathan Bither <jonbither@gmail.com>,
	"list@hauke-m.de:NETWORKING DRIVERS" <netdev@vger.kernel.org>,
	OpenWrt@venema.h4ckr.net,
	"antonynpavlov@gmail.com" <antonynpavlov@gmail.com>
To: Holger Schurig <holgerschurig@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpsmtpb-ews06.kpnxchange.com ([213.75.39.9]:64604 "EHLO
	cpsmtpb-ews06.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S966364AbaFRNnA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 09:43:00 -0400
In-Reply-To: <CAOpc7mE+829tBdy5atjtoJnGWDAnAHT_U0swXCuS3n_DMave1Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-06-18 at 15:15 +0200, Holger Schurig wrote:
> Hmm, wouldn't the obvious thing than to add the driver in it's current
> form into staging?  Is it well-separated from the rest of  Atheros
> WLAN drivers ?

A quick glance at the code shows an include of ar231x_platform.h (which
doesn't exist) and uses of struct ar231x_board_config (ditto). So it
won't build as is and therefor needs work to qualify for staging.


Paul Bolle
