From: Gustavo Pimentel <gustavo.pimentel@efacec.com>
Subject: Bonding
Date: Tue, 11 Feb 2014 13:53:32 +0000
Message-ID: <8532C3BD1ECBC64BA47CE43AFED6D38EC37E5AA5@S103.efacec.pt>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.efacec.com ([213.58.230.66]:8829 "HELO mail3.efacec.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750767AbaBKOFv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 09:05:51 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm writing you because because I'm have implemented a new mode (PRP Pa=
rallel Redundancy Protocol) for bonding kernel driver. This new mode is=
 quite simple, I don't know if you have heard about PRP, but it's a new=
 standard that allows to overcome any single network failure without af=
fecting the data transmission. The general idea resides on having two s=
eparate LAN (A & B) very similar and transmitting the almost the same f=
rame=A0through both LANs and the end device should accept one frame and=
 discard the other according to a known mechanism.=20

I have implemented this new mode on bonding driver, but I have some dif=
ficulties:
=2E Writing linux driver is quite new for me. I don't' know if exists g=
uide lines for driver coding.
=2E I don't know how to submit the code to be include on kernel reposit=
ory.
=2E Maybe another pair of eyes could find help to improve the writing c=
ode for this mode.

I think my driver code is 99% complete. I'm currently testing with 3 eq=
uipments (1 pc + 1 embedded device running both my modify bonding drive=
r) and a third party equipment called RedBox.

Would you be interested in participating / helping this project?

With my best regards,=20

Gustavo Gama da Rocha Pimentel
Power Systems Automation / Innovation & Development
Efacec Engenharia e Sistemas, S.A.
Phone: +351229403391
Disclaimer
