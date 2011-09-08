From: Viral Mehta <viral.vkm@gmail.com>
Subject: [RFC] interface for outgoing packet
Date: Wed, 7 Sep 2011 20:24:20 -0400
Message-ID: <CANX6DanC8DJsAZj4dV3oZo3DnLV6AyxBDm82vHaJm3C51aRqEg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:35902 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752991Ab1IHAYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2011 20:24:21 -0400
Received: by pzk37 with SMTP id 37so342771pzk.1
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2011 17:24:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

How reasonably I can assume that,

on whatever interface, I received the last packet
for a particular Socket Connection, the same interface will be
used to SEND the next packet for same socket connection?

I am collecting the logs on one of my test machines.
And it shows, I can assume all the time that "interface" which received packet
for some socket connection, the same will be used to send packet for
that connection

But, I am not sure if I am missing some scenarios
or setup (for e.g., bonding) where it can be wrong ?

It would be more help if some one can shed some light.
-- 
Thanks,
Viral Mehta
