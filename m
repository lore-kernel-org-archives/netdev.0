From: "David S. Miller" <davem@redhat.com>
Subject: Re: [BK PATCH] 2.6.2 SCTP updates
Date: Sun, 8 Feb 2004 10:39:21 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040208103921.68614451.davem@redhat.com>
References: <Pine.LNX.4.58.0402061649001.10831@localhost.localdomain>
	<20040206194518.56787717.davem@redhat.com>
	<Pine.LNX.4.58.0402080900450.25152@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <Pine.LNX.4.58.0402080900450.25152@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 8 Feb 2004 09:07:48 -0800 (PST)
Sridhar Samudrala <sri@us.ibm.com> wrote:

> I guess i was influenced by the TCP specific tcp_rmem/tcp_wmem. But TCP
> seems to be using them as a vector of 3 values and tuning the buffer sizes
> dynamically based on these values.
> As of now, SCTP doesn't do any tuning dynamically so i could have used the
> core rmem_default/wmem_default.
> 
> Do you want me to remove the specialized SCTP sysctl's?

It seems as duplication if there is no specific need to have seperate
controls right?
