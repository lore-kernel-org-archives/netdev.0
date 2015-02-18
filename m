From: Cong Wang <cwang@twopensource.com>
Subject: Re: getting a list of naked interface names from iproute2
Date: Wed, 18 Feb 2015 10:55:54 -0800
Message-ID: <CAHA+R7P_uqyuP4BR=zCjH1=m0pSTX3KPQd9bTuLARUa_KN0rjg@mail.gmail.com>
References: <54E28630.4020200@mthode.org>
	<20150217102358.67b9d826@uryu.home.lan>
	<54E418D2.3020406@mthode.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>
To: mthode@mthode.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:41026 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752134AbbBRSzy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2015 13:55:54 -0500
Received: by iecrd18 with SMTP id rd18so3621756iec.8
        for <netdev@vger.kernel.org>; Wed, 18 Feb 2015 10:55:54 -0800 (PST)
In-Reply-To: <54E418D2.3020406@mthode.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 17, 2015 at 8:45 PM, Matthew Thode <mthode@mthode.org> wrote:
> Do you happen to know a way to request it for a specific namespace?
> going over the links in /sys/class/net only gets you the current
> namespace (was the easiest method to do in python2.7).

The interface is not friendly. You need to open an fd which points to the
netns proc file or the pid of a task inside the namespace, take a look at how
`ip netns exec` is implemented.
