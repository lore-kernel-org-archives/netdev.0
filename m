From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: If bridge have no sub-interfaces, it's status may be still with
 'RUNNING'
Date: Mon, 16 Feb 2015 11:51:37 -0500
Message-ID: <20150216115137.5aa3f0cd@uryu.home.lan>
References: <54DDCA99.4040401@windriver.com>
	<20150213133056.3944c13e@uryu.home.lan>
	<54E17853.8070106@windriver.com>
	<54E210FF.2050502@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yzhu1 <Yanjun.Zhu@windriver.com>, netdev <netdev@vger.kernel.org>,
	"Wu, Kuaikuai" <Kuaikuai.Wu@windriver.com>,
	"Tao, Yue" <Yue.Tao@windriver.com>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f53.google.com ([209.85.192.53]:41107 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753163AbbBPQvk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2015 11:51:40 -0500
Received: by mail-qg0-f53.google.com with SMTP id f51so24139975qge.12
        for <netdev@vger.kernel.org>; Mon, 16 Feb 2015 08:51:39 -0800 (PST)
In-Reply-To: <54E210FF.2050502@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Originally bridge code would start with carrier off,
but there were users using bridge as a form of dummy device
and this broke them. Therefore it was decided (like 5 yrs ago),
that bridge should start with carrier on.
