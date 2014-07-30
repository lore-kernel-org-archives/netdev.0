From: "Banerjee, Debabrata" <dbanerje@akamai.com>
Subject: Re: [PATCH] tcp: don't require root to read tcp_metrics
Date: Wed, 30 Jul 2014 15:58:38 -0400
Message-ID: <CFFEC50E.38308%dbanerje@akamai.com>
References: <1406740415-9386-1-git-send-email-dbanerje@akamai.com>
 <alpine.LFD.2.11.1407302228460.1826@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S . Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay07.akamai.com ([72.246.2.115]:12209 "EHLO
	prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750969AbaG3T6l convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jul 2014 15:58:41 -0400
In-Reply-To: <alpine.LFD.2.11.1407302228460.1826@ja.home.ssi.bg>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 7/30/14, 3:33 PM, "Julian Anastasov" <ja@ssi.bg> wrote:
>On Wed, 30 Jul 2014, Debabrata Banerjee wrote:
>
>> commit d23ff701643a4a725e2c7a8ba2d567d39daa29ea introduced netlink
>>support for
>> the new tcp_metrics, however it restricted getting of tcp_metrics to
>>root user
>> only. This is a change from how these values could have been fetched
>>when in
>> the old route cache. Unless there's a legitimate reason to restrict the
>>reading
>> of these values it would be better if normal users could fetch them.
>
>	Not sure how fatal is to show TCP fastopen cookies to
>any user. Otherwise, I don't remember for other restrictions.


TFO cookie as reported is sent in the clear in the tcp header. It is not
the secret/key used to generate the cookie, so this should be fine.

-Debabrata
