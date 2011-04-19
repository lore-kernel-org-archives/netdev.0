From: Michal Marek <mmarek@suse.cz>
Subject: Re: [PATCH 17/34] hdlcdrv: Drop __TIME__ usage
Date: Tue, 19 Apr 2011 12:56:50 +0200
Message-ID: <4DAD6A72.2050809@suse.cz>
References: <1302015561-21047-1-git-send-email-mmarek@suse.cz> <1302015561-21047-18-git-send-email-mmarek@suse.cz> <4DAD614D.1060704@bfs.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kbuild@vger.kernel.org,
	Thomas Sailer <t.sailer@alumni.ethz.ch>,
	linux-hams@vger.kernel.org, netdev@vger.kernel.org
To: wharms@bfs.de
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <4DAD614D.1060704@bfs.de>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 19.4.2011 12:17, walter harms wrote:
> Am 05.04.2011 16:59, schrieb Michal Marek:
>> --- a/drivers/net/hamradio/hdlcdrv.c
>> +++ b/drivers/net/hamradio/hdlcdrv.c
>> @@ -749,7 +749,7 @@ EXPORT_SYMBOL(hdlcdrv_unregister);
>>  static int __init hdlcdrv_init_driver(void)
>>  {
>>  	printk(KERN_INFO "hdlcdrv: (C) 1996-2000 Thomas Sailer HB9JNX/AE4WA\n");
>> -	printk(KERN_INFO "hdlcdrv: version 0.8 compiled " __TIME__ " " __DATE__ "\n");
>> +	printk(KERN_INFO "hdlcdrv: version 0.8\n");
>>  	return 0;
>>  }
>>  
> 
> Its a bit late but i am not a big fan of hard coded version id's.
> Does GIT provide something like that ? If not
> IMHO the line
>  printk(KERN_INFO "hdlcdrv: version 0.8\n");
> can be removed.

OK, submit a separate patch then. I personally don't care about version
id's, as long as they do not embed any timestamp ;-).

Michal
