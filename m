From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [DOCUMENTATION PATCH] Missing net sysctls, some fixed, rest flagged
Date: Wed, 16 Jun 2004 10:37:19 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40D006BF.7020002@cosmosbay.com>
References: <20040609175242.GA13875@outpost.ds9a.nl> <20040615201912.691ffe35.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bert hubert <ahu@ds9a.nl>, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040615201912.691ffe35.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

>+somaxconn - INTEGER
>+	Limit of TCP listen backlog, known in userspace as SOMAXCONN.
>+	Defaults to 128
>+
>  
>
Hmm...

I dont agree with the 'TCP' word here : listen() system call is not tied 
with TCP, isn't it ?
I would suggest :

+somaxconn - INTEGER
+	Limit of socket listen() backlog, known in userspace as SOMAXCONN.
+	Defaults to 128. See also tcp_max_syn_backlog for additional tuning for TCP sockets.
+


Thank you

Eric Dumazet
