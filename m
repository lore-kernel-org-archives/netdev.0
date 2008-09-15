From: "Jerry Chu" <hkchu@google.com>
Subject: how to add seq_file based entry under /proc/sys?
Date: Mon, 15 Sep 2008 12:02:49 -0700
Message-ID: <d1c2719f0809151202r44acd4f5q57bfb3a16c26fcb5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:5853 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753392AbYIOTC4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2008 15:02:56 -0400
Received: from zps78.corp.google.com (zps78.corp.google.com [172.25.146.78])
	by smtp-out.google.com with ESMTP id m8FJ2odx002647
	for <netdev@vger.kernel.org>; Mon, 15 Sep 2008 20:02:50 +0100
Received: from gxk6 (gxk6.prod.google.com [10.202.11.6])
	by zps78.corp.google.com with ESMTP id m8FJ0b88003207
	for <netdev@vger.kernel.org>; Mon, 15 Sep 2008 12:02:49 -0700
Received: by gxk6 with SMTP id 6so28805563gxk.16
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2008 12:02:49 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm trying to add an entry with a seq_file type interface under
/proc/sys/net/ipv4.
I just discovered proc_sysctl related changes in 2.6.26 seems to demand a
ctl_table interface on all entries hence disallowing seq_file. Am I missing
something here? Any clue will be much appreciated.

Jerry
