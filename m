From: sandr8 <sandr8_NOSPAM_@crocetta.org>
Subject: [PATCH 0/4] deferred drop, __parent workaround, reshape_fail, ACCT
 unbilling and some cosmetics
Date: Fri, 13 Aug 2004 02:48:00 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <411C0FC0.4060703@crocetta.org>
Reply-To: sandr8_NOSPAM_@crocetta.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca, kuznet@ms2.inr.ac.ru, davem@redhat.com, devik@cdi.cz,
        shemminger@osdl.org, kaber@trash.net, rusty@rustcorp.com.au,
        laforge@netfilter.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This set of patches addresses some issues _apparently_ not tightly bound
one to the other one. i tested the whole patchset in two configurations, 
one with cbq + sfq + ingress and the other with a packet scheduler that 
i'm actually working on. i'd be very glad if somebody volunteers for 
more testing, although i would be even more happy if somebody could read 
attentively and countercheck what i have written. i have checked and 
double checked slowly and carefully myself but i would really appreciate 
if somebody else does some further bug hunting, just in case i forgot 
something or i've made some wrong assumption.

Alessandro Salvatori
--
the _NOSPAM_ account is the one i am subscribed with, please remove 
_NOSPAM_ for personal replies
