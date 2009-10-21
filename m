From: Gilad Ben-Yossef <gilad@codefidence.com>
Subject: Re: [PATCH v2 8/8] Document future removal of sysctl_tcp_* options
Date: Wed, 21 Oct 2009 12:23:21 +0200
Message-ID: <4ADEE119.7020803@codefidence.com>
References: <1256115421-12714-1-git-send-email-gilad@codefidence.com> <1256115421-12714-9-git-send-email-gilad@codefidence.com> <4ADED6FA.2030502@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ori@comsleep.com
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenbox.codefidence.com ([92.48.73.16]:42579 "EHLO
	xenbox.codefidence.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752730AbZJUKXV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 06:23:21 -0400
In-Reply-To: <4ADED6FA.2030502@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

William Allen Simpson wrote:

> Gilad Ben-Yossef wrote:
>> +What:    sysctl_tcp_sack, sysctl_tcp_timestamps, 
>> sysctl_tcp_window_scaling,
>> +    sysctl_tcp_dsack
>
> Opposed to removing, as this is a common configuration for *BSD.  It 
> helps
> operators to have similar utility across systems.
>
> net.inet.tcp.sack.enable
>
> net.inet.tcp.timestamps
>
> net.inet.tcp.win_scale
>
> Support removing sysctl_tcp_dsack, as this appears to be Linux-only.

I have no issue with leaving those, if everyone thinks we're better off.

BTW, while we're talking about OS envy, I do believe that Windows do let
you specify on a per route basis. Not that this is really a good ground for
technical decision, but still... :-)

Gilad

-- 
Gilad Ben-Yossef
Chief Coffee Drinker & CTO
Codefidence Ltd.

Web:   http://codefidence.com
Cell:  +972-52-8260388
Skype: gilad_codefidence
Tel:   +972-8-9316883 ext. 201
Fax:   +972-8-9316884
Email: gilad@codefidence.com

Check out our Open Source technology and training blog - http://tuxology.net

	"Sorry cannot parse this, its too long to be true  :)"
	  -- Eric Dumazet on netdev mailing list

