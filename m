From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH NEXT] rtlwifi: Fix endian error in extracting packet type
Date: Tue, 29 Oct 2013 15:16:35 -0500
Message-ID: <527017A3.9020109@lwfinger.net>
References: <1383002903-8746-1-git-send-email-Larry.Finger@lwfinger.net>	<1383005246.3779.61.camel@bwh-desktop.uk.level5networks.com> <87y55cf8yq.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	Mark Cave-Ayland <mark.cave-ayland@ilande.co.uk>,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>
To: =?UTF-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>,
	Ben Hutchings <bhutchings@solarflare.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <87y55cf8yq.fsf@nemi.mork.no>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/29/2013 09:27 AM, Bj=C3=B8rn Mork wrote:
>
> It's not validating the upper 8 bits of the port numbers either, so i=
t
> will hit random UDP traffic in addition to DHCP.
>
> But it was good to see this function now. I was wondering how to supp=
ort
> some buggy 3G modem firmware without ugly hacks. Seems there will alw=
ays
> be worse hacks in drivers/net, no matter what I do :-)

I'm happy that Realtek and I could make your day. The next version is c=
hecking=20
the full 16-bit port numbers.

Thanks,

Larry
