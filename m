From: Stas Sergeev <stsp@list.ru>
Subject: Re: [PATCH 2/2] mvneta: use inband status only when link type is
 "auto"
Date: Thu, 9 Jul 2015 23:26:25 +0300
Message-ID: <559ED8F1.7050609@list.ru>
References: <559EB0A4.5080101@list.ru> <559EB22E.7070607@list.ru>
 <559EBAFE.6040705@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux kernel <linux-kernel@vger.kernel.org>,
	Sebastien Rannou <mxs@sbrk.org>,
	Arnaud Ebalard <arno@natisbad.org>,
	Stas Sergeev <stsp@users.sourceforge.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	netdev <netdev@vger.kernel.org>, stable@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <559EBAFE.6040705@gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

09.07.2015 21:18, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On 09/07/15 10:41, Stas Sergeev wrote:
>> The commit 898b2970e2c9 ("mvneta: implement SGMII-based in-band link=
 state
>> signaling") implemented the link parameters auto-negotiation uncondi=
tionally.
>> Unfortunately it appears that some HW that implements SGMII protocol=
,
>> doesn't generate the inband status, so it is not possible to auto-ne=
gotiate
>> anything with such HW.
> What is the purpose of using the in-band status in the first place if
> you end-up having to specify a 'fixed-link' property which contains m=
ost
> of the link parameters: speed, duplex etc...?
You don't have to.
My config from today is as simple as:

fixed-link {
   link =3D "auto";
};

and that's all.
Without my today's patch, only 'speed' is a mandatory - not too much.
