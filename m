From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: The ultimate TOE design
Date: Thu, 16 Sep 2004 09:18:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4149BCE9.7040501@us.ibm.com>
References: <200409161310.i8GDAnqG005123@guinness.s2io.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'Andi Kleen'" <ak@suse.de>, "'David S. Miller'" <davem@davemloft.net>,
        "'John Heffner'" <jheffner@psc.edu>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Leonid Grossman <leonid.grossman@s2io.com>
In-Reply-To: <200409161310.i8GDAnqG005123@guinness.s2io.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Leonid Grossman wrote:

> We can dream about benefits of huge MTUs, but the reality is that moving
> beyond 9k MTU is years away. Reasons - mainly infrastructure, plus MTU above
> ~10k may loose checksum protection (granted, this depends whether the errors
> are simple or complex, and also this may not be a showstopper for some
> people).
> Even 9k MTU is very far from being universally accepted, eight years after
> our Alteon spec went out :-).

One other factor is TCP congestion control, and congestion
windows we obey. Most of the time, you just can't send that
much.

thanks,
Nivedita
