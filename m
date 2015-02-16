From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: If bridge have no sub-interfaces, it's status may be still with
 'RUNNING'
Date: Mon, 16 Feb 2015 11:52:14 -0500
Message-ID: <20150216115214.5430f51d@uryu.home.lan>
References: <54DDCA99.4040401@windriver.com>
	<20150213133056.3944c13e@uryu.home.lan>
	<54E17853.8070106@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Wu, Kuaikuai" <Kuaikuai.Wu@windriver.com>,
	"Tao, Yue" <Yue.Tao@windriver.com>
To: yzhu1 <Yanjun.Zhu@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:43191 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753163AbbBPQwR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2015 11:52:17 -0500
Received: by iebtr6 with SMTP id tr6so24576236ieb.10
        for <netdev@vger.kernel.org>; Mon, 16 Feb 2015 08:52:16 -0800 (PST)
In-Reply-To: <54E17853.8070106@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 16 Feb 2015 12:55:47 +0800
yzhu1 <Yanjun.Zhu@windriver.com> wrote:

> Hi, Stephen
> 
> Follow your advice, I made a new patch. This patch will turn off
> carrier when a new bridge interface is created. Please comment on it.
> 
> Thanks a lot.
> Zhu Yanjun

NAK.
We need to keep the current behavior to not break corner case users.
