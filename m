From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: fix TCP roundtrip time update code
Date: Tue, 03 Jun 2003 21:40:18 -0700
Sender: linux-ia64-admin@linuxia64.org
Message-ID: <3EDD7832.7010804@us.ibm.com>
References: <200306040043.EAA24505@dub.inr.ac.ru>	<3EDD52F5.8090706@us.ibm.com>	<20030603.202320.59680883.davem@redhat.com> <16093.30507.661714.676184@napali.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, kuznet@ms2.inr.ac.ru,
   jmorris@intercode.com.au, gandalf@wlug.westbo.se,
   linux-kernel@vger.kernel.org, linux-ia64@linuxia64.org, netdev@oss.sgi.com,
   akpm@digeo.com
Return-path: <linux-ia64-admin@linuxia64.org>
To: davidm@hpl.hp.com
In-Reply-To: <16093.30507.661714.676184@napali.hpl.hp.com>
Errors-To: linux-ia64-admin@linuxia64.org
List-Help: <mailto:linux-ia64-request@linuxia64.org?subject=help>
List-Post: <mailto:linux-ia64@linuxia64.org>
List-Subscribe: <http://lists.linuxia64.org/lists/listinfo/linux-ia64>,
	<mailto:linux-ia64-request@linuxia64.org?subject=subscribe>
List-Unsubscribe: <http://lists.linuxia64.org/lists/listinfo/linux-ia64>,
	<mailto:linux-ia64-request@linuxia64.org?subject=unsubscribe>
List-Archive: <http://lists.linuxia64.org/archives//linux-ia64/>
List-Id: netdev.vger.kernel.org

David Mosberger wrote:

>   DaveM> So if your old SpecWEB99 lab tended more to trigger timeout
>   DaveM> based retransmits on LAN, and your new test network does not,
>   DaveM> then your new test network will tend to not reproduce the bug
>   DaveM> regardless of whether the bug is present in the kernel or not
>   DaveM> :-)
> 
> Is this where I get to plug httperf?  It triggered the bug reliably in
> less than 10 secs. ;-)

Tarnation!! Ran httperf! Didnt hit it! :(. What were your
settings?

I extracted an old debug patch to implement dropping of
packets - have a sysctl that controls the rate at which I
can drop IP packets, so can also generate any kind of packet
loss..So thought I would bang away with netperf using
sendfile()/TCP_CORK. Thought it was in that code path.
Will be running tests tmrw and the rest of this
week on 2.5.70 +- patch. Will see if I can provoke any
further hangs, stalls, wackiness of any flavor...

thanks,
Nivedita
