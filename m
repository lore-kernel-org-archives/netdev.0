From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: Missed stable line commit (upstream
 859828c0ea476b42f3a93d69d117aaba90994b6f)
Date: Tue, 18 Nov 2014 17:19:33 -0800
Message-ID: <20141119011933.GA22731@kroah.com>
References: <CAKTPYJQQprPnN1bUPxy32YREb8WARQztQYWL9-Qfhm6wLqbD0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	stable@vger.kernel.org
To: Andrew Collins <bsderandrew@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAKTPYJQQprPnN1bUPxy32YREb8WARQztQYWL9-Qfhm6wLqbD0A@mail.gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 03, 2014 at 03:11:01PM -0700, Andrew Collins wrote:
> I ran into an issue today on latest 3.10 stable line that looks to
> have been resolved upstream and tagged for stable:
> 
> commit 859828c0ea476b42f3a93d69d117aaba90994b6f
> Author: Jiri Pirko <jiri@resnulli.us>
> Date:   Thu Dec 5 16:27:37 2013 +0100
> 
>     br: fix use of ->rx_handler_data in code executed on non-rx_handler path
>     ...
>     Please apply to stable trees as well. Thanks.
> 
> The commit did make it into the 3.12 stable line, but seems to have
> been missed in 3.10.  The commit that causes the issue *did* make it
> into 3.10.16 so 3.10 is exposed to the issue:
> 
> commit 960b8e5018a552f62cfbc0dfe94be7b6ba178f13
> Author: Hong Zhiguo <zhiguohong@tencent.com>
> Date:   Sat Sep 14 22:42:28 2013 +0800
> 
>     bridge: fix NULL pointer deref of br_port_get_rcu
> 
>     [ Upstream commit 716ec052d2280d511e10e90ad54a86f5b5d4dcc2 ]
> 
> Any chance 859828c0ea476b42f3a93d69d117aaba90994b6f could be pulled
> into the next 3.10 stable?

Now queued up, thanks.

greg k-h
