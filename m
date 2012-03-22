From: Josh Hunt <joshhunt00@gmail.com>
Subject: long-lived tcp connection question
Date: Thu, 22 Mar 2012 11:56:19 -0500
Message-ID: <CAKA=qzaPwx53ExK7VhNC_sbv3tVZrnWXv-5Fh8akcZ6DEaqd9Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:44250 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751372Ab2CVQ4U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2012 12:56:20 -0400
Received: by yenl12 with SMTP id l12so1934819yen.19
        for <netdev@vger.kernel.org>; Thu, 22 Mar 2012 09:56:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Given things like web sockets with presumably long-lived persistent
tcp connections and a sparse amount of data, I was wondering if there
are currently any mechanisms in the kernel or out of tree projects
which work on reducing the overhead these connections require?
Possibly storing their state after a certain period of inactivity and
then reviving them when work needs to be done? I'm thinking something
along the lines of the state info stored for time-wait sockets and
then the ability to resurrect it on an incoming packet. Keeping
resources around for such connections seems inefficient although
possibly unavoidable.

Thanks
Josh
