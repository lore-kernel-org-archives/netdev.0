From: yan cui <ccuiyyan@gmail.com>
Subject: dynamic TCP algorithms switching
Date: Fri, 22 Nov 2013 17:49:58 -0500
Message-ID: <CAAVq3rnxE92PsJOChr+H52k5QfG7E=hAjsohK4Um0ZRO9TdYuA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org, linux-net@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:60094 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755577Ab3KVWuA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Nov 2013 17:50:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all:

   Currently, Linux has kinds of TCP congestion algorithms, such as
reno, cubic, bic, hybla, ...., and each TCP congestion algorithm has
its target networking environment. I just wonder to know is it
possible to do dynamic TCP algorithm switching? In other words, the
system has a combined TCP congestion algorithm (say, TCP-auto), and it
behaves like one of the integrated TCP congestion algorithms according
to different detected networking environment, but can switch to a
different one. For example, TCP-auto totally uses the set of
congestion control operations in TCP-cubic by default, but when it
detects that the current OS uses wireless networking, it switches to
some wireless friendly TCP congestion algorithm. Does Linux have some
features like that, or do you (networking developers and users) care
about it?

Best Wishes!

-- 
Think big; Dream impossible; Make it happen.
