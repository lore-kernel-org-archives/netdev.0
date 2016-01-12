From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 3/3] bonding: make device count build-time configurable
Date: Tue, 12 Jan 2016 22:40:35 +0100
Message-ID: <87bn8qv5m4.fsf@nemi.mork.no>
References: <1452599916-27511-1-git-send-email-lkundrak@v3.sk>
	<8166.1452616452@famine> <1452619189.18559.83.camel@v3.sk>
	<20160112.154914.397367508465928770.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lkundrak@v3.sk, jay.vosburgh@canonical.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, vfalico@gmail.com,
	gospo@cumulusnetworks.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160112.154914.397367508465928770.davem@davemloft.net> (David
	Miller's message of "Tue, 12 Jan 2016 15:49:14 -0500 (EST)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:
> From: Lubomir Rintel <lkundrak@v3.sk>
> Date: Tue, 12 Jan 2016 18:19:49 +0100
>
>> It's still an improvement to let the distributions decide if they're
>> keeping "ip link add" broken or possibly affecting the scripts.
>
> That it is "broken" is your opinion.
>
> Document the behavior.  It is not broken if the user is told to be
> mindful of what devices are created by default.
>
> There is way too much downside to changing this.

Besides, distributions or admins can already change that behaviour if
they consider it "broken", using the existing module parameter:

 # echo "options bonding max_bonds=3D0" >/etc/modprobe.d/bonding.conf
 # rmmod bonding
 # ip link add bond0 type bond
 (no error here)

This method should be well known and understood by most users, contrary
to some odd CONFIG_ build time setting.


Bj=C3=B8rn
