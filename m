From: Patrick McHardy <kaber@trash.net>
Subject: Re: Dynamically classifying flows?
Date: Tue, 08 Mar 2005 01:25:20 +0100
Message-ID: <422CF0F0.3020407@trash.net>
References: <7bca1cb505030709502316f9b8@mail.gmail.com>	 <20050307203450.GX31837@postel.suug.ch> <7bca1cb505030716104856fe3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, netdev@oss.sgi.com
To: Asim Shankar <asimshankar@gmail.com>
In-Reply-To: <7bca1cb505030716104856fe3@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Asim Shankar wrote:
>>It is a likely scenario but usually not a problem because you can classify this
>>kind of bulk packets by their size. u32 can be used use for such things or the
>>newly added meta ematch.
> 
> Filtering by size may not always work. An interactive flow may also
> generate big (MTU) size packets, but it is interactive because the
> _rate_ at which packets are produced is smaller. Though, if you think
> that such cases are purely theoretical and don't create problems in
> practice, do let me know.

The connbytes and the connrate match from netfilter patch-o-matic can
be used to dynamically reclassify demanding connections. Keep in mind
that reclassification can cause reordering, so you should make sure
it can't happen frequently for single connections.

Regards
Patrick
