From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: fix TCP roundtrip time update code
Date: Tue, 03 Jun 2003 19:01:25 -0700
Sender: linux-ia64-admin@linuxia64.org
Message-ID: <3EDD52F5.8090706@us.ibm.com>
References: <200306040043.EAA24505@dub.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: James Morris <jmorris@intercode.com.au>, davidm@hpl.hp.com,
   gandalf@wlug.westbo.se, linux-kernel@vger.kernel.org,
   linux-ia64@linuxia64.org, netdev@oss.sgi.com, davem@redhat.com,
   akpm@digeo.com
Return-path: <linux-ia64-admin@linuxia64.org>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200306040043.EAA24505@dub.inr.ac.ru>
Errors-To: linux-ia64-admin@linuxia64.org
List-Help: <mailto:linux-ia64-request@linuxia64.org?subject=help>
List-Post: <mailto:linux-ia64@linuxia64.org>
List-Subscribe: <http://lists.linuxia64.org/lists/listinfo/linux-ia64>,
	<mailto:linux-ia64-request@linuxia64.org?subject=subscribe>
List-Unsubscribe: <http://lists.linuxia64.org/lists/listinfo/linux-ia64>,
	<mailto:linux-ia64-request@linuxia64.org?subject=unsubscribe>
List-Archive: <http://lists.linuxia64.org/archives//linux-ia64/>
List-Id: netdev.vger.kernel.org

kuznet@ms2.inr.ac.ru wrote:

> No doubts. All the symptoms are explained by this. I hope Andrew
> will confirm that the problem has gone.

Yep, great catch! But, FYI, DaveM and Alexey, we tried
reproducing the stalls we (Dave Hansen, Troy Wilson) had
seen during SpecWeb99 runs and couldn't reproduce them on
2.5.69. (Same config, etc). So its possible our hang/stalls
were some other issue that got silently fixed (or more
likely, possibly the same thing but other changes minimized
us running into the problem).

thanks,
Nivedita
