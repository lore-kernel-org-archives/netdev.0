From: Prashant Batra <prbatra.lists@gmail.com>
Subject: attach multiple programs to tun/tap interface
Date: Mon, 01 Apr 2013 22:42:21 +0530
Message-ID: <5159BFF5.90209@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, linux-newbie@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:62493 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755789Ab3DARNY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Apr 2013 13:13:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have a basic query on tun/tap driver design. Is it possible to attach=
=20
multiple user-space programs to the same tun/tap interface. I have not=20
set the interface as EXCLUSIVE,
but still on trying to do ioctl with cmd as =93TUNSETIFF=94 from the se=
cond=20
user space program, I get =93Device busy=94.

Seeing through the driver code, it looks like it does not allow multipl=
e=20
user-programs to attach to the same interface, but is this valid, and=20
please let me know why this requirement was taken.

Will you please help me in understanding this?

Thanks,
Prashant
