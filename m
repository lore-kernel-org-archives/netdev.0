From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [net-next 08/11] e1000e: add Receive Packet Steering (RPS) support
Date: Tue, 3 Jan 2012 18:06:27 -0800
Message-ID: <CAHLZz12LZ9CxAc_uPjbtckkbM8YAeyeZX3MczBP1mZq8PeWg_w@mail.gmail.com>
References: <1325618356-2655-9-git-send-email-jeffrey.t.kirsher@intel.com>
	<20120103.150936.572765552893657192.davem@davemloft.net>
	<804857E1F29AAC47BF68C404FC60A1840292A5@ORSMSX102.amr.corp.intel.com>
	<20120103.152739.1456113375065412910.davem@davemloft.net>
	<804857E1F29AAC47BF68C404FC60A18402A7BC@ORSMSX102.amr.corp.intel.com>
	<1325635974.24257.20.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Allan, Bruce W" <bruce.w.allan@intel.com>,
	David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:46853 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752549Ab2ADCG2 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jan 2012 21:06:28 -0500
Received: by obcwo16 with SMTP id wo16so13195189obc.19
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2012 18:06:27 -0800 (PST)
In-Reply-To: <1325635974.24257.20.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 3, 2012 at 4:12 PM, Joe Perches <joe@perches.com> wrote:
> On Tue, 2012-01-03 at 20:28 +0000, Allan, Bruce W wrote:
>> +
>> + =C2=A0 =C2=A0 /* Fill out hash function seeds */
>> + =C2=A0 =C2=A0 for (j =3D 0; j < 10; j++) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 u32 rsskey =3D rsshash[(=
j * 4)];
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rsskey |=3D rsshash[(j *=
 4) + 1] << 8;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rsskey |=3D rsshash[(j *=
 4) + 2] << 16;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rsskey |=3D rsshash[(j *=
 4) + 3] << 24;
>

Perhaps consider get_unaligned_le32()

Cheers,

Harvey
