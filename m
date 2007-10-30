From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/2] Convert /proc/net/ipv6_route to seq_file interface
Date: Tue, 30 Oct 2007 16:37:09 +0100
Message-ID: <47274FA5.8070902@trash.net>
References: <20071030131147.GA6210@localhost.sw.ru> <20071030083043.47f5def3@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63976 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754208AbXJ3Pjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 11:39:43 -0400
In-Reply-To: <20071030083043.47f5def3@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Tue, 30 Oct 2007 16:11:47 +0300
> Alexey Dobriyan <adobriyan@sw.ru> wrote:
>>  
>> +static const struct file_operations ipv6_route_proc_fops = {
>> +	.open		= ipv6_route_open,
>> +	.read		= seq_read,
>> +	.llseek		= seq_lseek,
>> +	.release	= single_release,
>> +};
>> +
> 
> This needs
> 	.owner		= THIS_MODULE,


Your ip_queue conversion patch was also missing this, I've
fixed it up.

