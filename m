From: =?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita@gmail.com>
Subject: Re: [PATCHv2 00/10] RFKill airplane-mode indicator
Date: Mon, 22 Feb 2016 14:35:57 -0500
Message-ID: <CA+A7VXU_8e9wVqr7AXu_2z9+68BTb-4jBBJBCgdgwiXRcYWkog@mail.gmail.com>
References: <1456159001-20307-1-git-send-email-jprvita@endlessm.com> <1456160420.16083.3.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	Darren Hart <dvhart@infradead.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	platform-driver-x86@vger.kernel.org, linux-api@vger.kernel.org,
	linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	linux@endlessm.com,
	=?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita@endlessm.com>
To: Dan Williams <dcbw@redhat.com>
Return-path: <platform-driver-x86-owner@vger.kernel.org>
In-Reply-To: <1456160420.16083.3.camel@redhat.com>
Sender: platform-driver-x86-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 22 February 2016 at 12:00, Dan Williams <dcbw@redhat.com> wrote:
> On Mon, 2016-02-22 at 11:36 -0500, Jo=C3=A3o Paulo Rechi Vita wrote:
>> This series implements an airplane-mode indicator LED trigger, which
>> can be
>> used by platform drivers. The default policy have have airplane-mode
>> set when
>> all the radios known by RFKill are OFF, and unset otherwise. This
>> policy can be
>> overwritten by one single userspace application at a time using the
>> operations
>> _AIRPLANE_MODE_INDICATOR_ACQUIRE and _AIRPLANE_MODE_INDICATOR_CHANGE=
=2E
>>
> Double-check your commit messages on some of these patches; they didn=
't
> get updated to add INDICATOR.
>

Thanks for catching this, Dan. I've sent an updated version fixing
this problem in reply to the patch where this slept through (9/10).

--
Jo=C3=A3o Paulo Rechi Vita
http://about.me/jprvita
