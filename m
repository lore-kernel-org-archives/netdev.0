From: P@draigBrady.com
Subject: flow control in e100
Date: Tue, 15 Jun 2004 21:14:36 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40CF58AC.2060802@draigBrady.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I'm using the e100 V3.0.13, and I've
a few questions regarding flow control.

This logic is crying out for a comment...

[config->fc_disable=3D0;]
if(nic->mac >=3D mac_82558_D101_A4) {
     config->fc_disable =3D 0x1;       /* 1=3DTx fc off, 0=3DTx fc on */
}

Also how does one query set flow control?
ethtool -[aA] doesn't seem to be supported.

thanks,
P=C3=A1draig.
