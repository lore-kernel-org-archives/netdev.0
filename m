From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] select congestion control with one sysctl
Date: Wed, 23 Feb 2005 16:23:02 -0800
Message-ID: <421D1E66.5090301@osdl.org>
References: <421CF5E5.1060606@ev-en.org> <20050223135732.39e62c6c.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Baruch Even <baruch@ev-en.org>, netdev@oss.sgi.com,
        linux-net@vger.kernel.org, yee-ting.li@nuim.ie, doug.leith@nuim.ie
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050223135732.39e62c6c.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

>For the millionth time, you can't just delete the existing sysctls.
>That is a user visisble interface.
>
>Instead, you have to make them at least appear to select a
>single congestion control algorithm as I stated in the
>following posting:
>
>http://marc.theaimsgroup.com/?l=linux-kernel&m=110909973530321&w=2
>  
>
I am heading in a different direction with making the TCP congestion 
protocols
a real infrastructure.  After the initial version gets done, then I will 
go back
and add compatiablity interface hooks as required.
