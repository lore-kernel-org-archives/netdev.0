From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 8/9] rfkill: Userspace control for airplane mode
Date: Wed, 10 Feb 2016 18:12:41 +0100
Message-ID: <ec4b7edcda0a62cd4e36e501f5ad56f9@sipsolutions.net>
References: <1454946096-9752-1-git-send-email-jprvita@endlessm.com>
 <1454946096-9752-9-git-send-email-jprvita@endlessm.com>
 <1454947887.5325.8.camel@redhat.com>
 <1455120444.4991.1.camel@sipsolutions.net>
 <1455123205.19821.34.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Darren Hart <dvhart@infradead.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	platform-driver-x86@vger.kernel.org, linux-api@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux@endlessm.com,
	=?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita@endlessm.com>
To: Dan Williams <dcbw@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455123205.19821.34.camel@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016-02-10 17:53, Dan Williams wrote:
> Yeah, I get that now. =C2=A0It's just that to me, something called
> "AIRPLANE_MODE_CHANGE" seems like it should actually change airplane
> mode on/off, which implies killing radios. =C2=A0I wouldn't have had =
the
> problem if it was named AIRPLANE_MODE_INDICATOR_CHANGE, which makes i=
t
> clear this is simply an indicator and has no actual effect on anythin=
g
> other than a LED.

Yeah, I agree. I'm not even sure that it's a good idea to subsume this=20
into the regular operations in the API, although that's obviously the=20
easiest extension. I'll need to think about that a bit more with the=20
code at hand though.

johannes
