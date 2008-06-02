From: "Akinobu Mita" <akinobu.mita@gmail.com>
Subject: Re: [patch -v2 01/23] sunrpc: use simple_read_from_buffer
Date: Mon, 2 Jun 2008 21:11:19 +0900
Message-ID: <961aa3350806020511u78896881raef7f5e12b94c121@mail.gmail.com>
References: <20080601231329.223608711@gmail.com>
	 <20080601231451.529328123@gmail.com>
	 <20080602053552.GA6592@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Alexey Dobriyan" <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.239]:10597 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757981AbYFBMLT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2008 08:11:19 -0400
Received: by rv-out-0506.google.com with SMTP id l9so1013787rvb.1
        for <netdev@vger.kernel.org>; Mon, 02 Jun 2008 05:11:19 -0700 (PDT)
In-Reply-To: <20080602053552.GA6592@martell.zuzino.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> +     len = sprintf(tbuf, "%lu\n", cd->flush_time);
>> +
>> +     return simple_read_from_buffer(buf, count, ppos, tbuf, len);
>>  }
>
> Please, switch to seq_file:
>
>        seq_printf(m, "%lu\n", cd->flush_time);
>        return 0;
>
> and that's everything module have to worry about.
>

OK. I'll drop this patch from the patch series.
And I'll send this seq_file convertion in another chance.
