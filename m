From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] dccp/tcp: fix routing redirect race
Date: Wed, 08 Mar 2017 18:10:57 -0800
Message-ID: <1489025457.28631.19.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1489022121-20571-1-git-send-email-jmaxwell37@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: gerrit@erg.abdn.ac.uk, davem@davemloft.net, edumazet@google.com,
        andreyknvl@google.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, ncardwell@google.com,
        dccp@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, jmaxwell@redhat.com,
        Eric Garver <egarver@redhat.com>,
        Hannes Sowa <hsowa@redhat.com>
To: Jon Maxwell <jmaxwell37@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489022121-20571-1-git-send-email-jmaxwell37@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-03-09 at 12:15 +1100, Jon Maxwell wrote:
> We have seen a few incidents lately where a dst_enty has been freed
> with a dangling TCP socket reference (sk->sk_dst_cache) pointing to that
> dst_entry. If the conditions/timings are right a crash then ensues when the
> freed dst_entry is referenced later on. A Common crashing back trace is:

Very nice catch !

Don't we have a similar issue for IPv6 ?
