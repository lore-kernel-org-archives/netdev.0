From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 1/4]  net/ne2k-pci: module_param conversion
Date: Wed, 24 Nov 2004 15:05:09 -0500
Message-ID: <41A4E975.8070102@pobox.com>
References: <E1CVLFE-0002CL-PU@sputnik>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, domen@coderock.org
Return-path: <netdev-bounce@oss.sgi.com>
To: janitor@sternwelten.at
In-Reply-To: <E1CVLFE-0002CL-PU@sputnik>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

janitor@sternwelten.at wrote:
> @@ -443,8 +435,7 @@ static void ne2k_pci_reset_8390(struct n
>  {
>  	unsigned long reset_start_time = jiffies;
>  
> -	if (debug > 1) printk("%s: Resetting the 8390 t=%ld...",
> -						  dev->name, jiffies);
> +	printk(KERN_INFO "%s: Resetting the 8390 t=%ld...", dev->name, jiffies);


The rest of the patch looks OK.

This chunk changes behavior, by removing the 'if' test.

	Jeff
