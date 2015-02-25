From: yzhu1 <Yanjun.Zhu@windriver.com>
Subject: Re: If bridge have no sub-interfaces, it's status may be still with
 'RUNNING'
Date: Wed, 25 Feb 2015 10:55:53 +0800
Message-ID: <54ED39B9.4090107@windriver.com>
References: <54DDCA99.4040401@windriver.com>	<20150213133056.3944c13e@uryu.home.lan>	<54E17853.8070106@windriver.com>	<54E210FF.2050502@gmail.com>,<20150216115137.5aa3f0cd@uryu.home.lan> <E66F6C44A7A6EA49ABFC80EA526506DF65AEAEB3@ALA-MBB.corp.ad.wrs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Wu, Kuaikuai" <Kuaikuai.Wu@windriver.com>,
	"Tao, Yue" <Yue.Tao@windriver.com>
To: Stephen Hemminger <stephen@networkplumber.org>,
	David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:45506 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751179AbbBYC5F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 21:57:05 -0500
In-Reply-To: <E66F6C44A7A6EA49ABFC80EA526506DF65AEAEB3@ALA-MBB.corp.ad.wrs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Stephen && David

Any update?

Zhu Yanjun

On 02/18/2015 12:14 AM, Zhu, Yanjun wrote:
> Hi, all
>
> We should make it compatible. So I made a patch to turn on carrier on this bridge interface when the last sub interface is removed.
>
> Hi, David
>
> Please make tests with this latest patch. Thanks a lot.
>
> Best Regards!
> Zhu Yanjun
> ________________________________________
> From: Stephen Hemminger [stephen@networkplumber.org]
> Sent: Monday, February 16, 2015 8:51 AM
> To: David Ahern
> Cc: Zhu, Yanjun; netdev; Wu, Kuaikuai; Tao, Yue
> Subject: Re: If bridge have no sub-interfaces, it's status may be still with 'RUNNING'
>
> Originally bridge code would start with carrier off,
> but there were users using bridge as a form of dummy device
> and this broke them. Therefore it was decided (like 5 yrs ago),
> that bridge should start with carrier on.
