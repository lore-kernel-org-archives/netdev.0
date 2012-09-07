From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: changing usbnet's API to better deal with cdc-ncm
Date: Fri, 7 Sep 2012 20:58:25 +0800
Message-ID: <CACVXFVOmjvJQVWGzff_t7Hn7oAOxFzfV1CXyJWhuuBqjFcM3eQ@mail.gmail.com>
References: <2791550.LhGu6po6Xy@linux-lqwf.site>
	<2AC7D4AD8BA1C640B4C60C61C8E520154A6AA56BF9@EXDCVYMBSTM006.EQ1STM.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Oliver Neukum <oneukum@suse.de>, "bjorn@mork.no" <bjorn@mork.no>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	Alexey Orishko <alexey.orishko@gmail.com>
To: Alexey ORISHKO <alexey.orishko@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:47896 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753276Ab2IGM61 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2012 08:58:27 -0400
In-Reply-To: <2AC7D4AD8BA1C640B4C60C61C8E520154A6AA56BF9@EXDCVYMBSTM006.EQ1STM.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 6, 2012 at 4:13 PM, Alexey ORISHKO
<alexey.orishko@stericsson.com> wrote:
>> -----Original Message-----
>> From: Oliver Neukum [mailto:oneukum@suse.de]
>
>
>> looking at cdc-ncm it seeems to me that cdc-ncm is forced to play very
>> dirty games because usbnet doesn't have a notion about aggregating
>> packets for a single transfer.
>
> Several issues need to be improved:
> Tx path:
> 1. IP packets must be accumulated in one NTB. Currently it's done via data copy.
> Preferred way would be a possibility to have a list of skb-s in resulting frame sent down.

Looks the copy is inevitable because the buffer length of each skb in the
list is not possible to be max endpoint packet aligned, so one short packet
may terminate the current tx urb transfer.


Thanks,
-- 
Ming Lei
