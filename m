From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v7 24/24] switchdev: bring documentation up-to-date
Date: Tue, 12 May 2015 22:37:24 -0700
Message-ID: <CAE4R7bB2Ec-9geSNjf08Q0g5esa39HMz-cw+rswkx+R8YdCV4Q@mail.gmail.com>
References: <1431276489-64199-1-git-send-email-sfeldma@gmail.com>
	<1431276489-64199-25-git-send-email-sfeldma@gmail.com>
	<9B0331B6EBBD0E4684FBFAEDA55776F9193B7848@HASMSX110.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jiri@resnulli.us" <jiri@resnulli.us>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"linux@roeck-us.net" <linux@roeck-us.net>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	"simon.horman@netronome.com" <simon.horman@netronome.com>,
	"joe@perches.com" <joe@perches.com>,
	"Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
	"Arad, Ronen" <ronen.arad@intel.com>
To: "Rosen, Rami" <rami.rosen@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f173.google.com ([209.85.216.173]:34024 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750909AbbEMFh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 01:37:26 -0400
Received: by qcyk17 with SMTP id k17so17134361qcy.1
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 22:37:25 -0700 (PDT)
In-Reply-To: <9B0331B6EBBD0E4684FBFAEDA55776F9193B7848@HASMSX110.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 11, 2015 at 2:02 PM, Rosen, Rami <rami.rosen@intel.com> wrote:
> Thanks for the good work.
>
> Minor comments:
>>+      bridge fdb add ADDR dev DEV [vlan VID] [self]
>
> I suggest consider adding in this section:
>  XXX: what should be done if offloading this rule to hardware fails (for example, due to full capacity in hardware tables) ?

I added that XXX note.

> Apart from it, two typos:
>
>>particularly useful for dynically-named ports where the device names
> Should be: dynamically-named ports.
>
>> resposible for partitioning hardware to preserve netns containment
> Should be: responsible.

Sending fix switchdev.txt with your/Jiri comments addressed....
