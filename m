From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [NET] make all protos partially use sk_prot
Date: Sat, 26 Mar 2005 14:36:03 +0100
Message-ID: <1111844163.9195.191.camel@pegasus>
References: <20050326003937.GA13951@conectiva.com.br>
	 <1111842541.9195.183.camel@pegasus>
	 <39e6f6c705032605136bd797b2@mail.gmail.com>
	 <39e6f6c7050326051571ef8272@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
        "David S. Miller" <davem@davemloft.net>,
        Network Development Mailing List <netdev@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <39e6f6c7050326051571ef8272@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Arnaldo,

> Ah, apart from these style changes, do you think the real changes in this patch
> are worth?

actually I am the wrong person to judge on this. However if socket users
don't have to care about owner and slab anymore (or at least less), I
think it is a good thing to do.

Btw all the ".slab = NULL," stuff in the proto declarations is not
needed and we normally omit values that are 0 or NULL.

And some of the proto__seq_* functions are not static. What is the
reason to have them public?

Regards

Marcel
