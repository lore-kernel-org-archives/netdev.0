From: "Oskar Andreasson" <blueflux@koffein.net>
Subject: [possibly O-T] ip-sysctl calls and a few questions.
Date: Fri, 3 May 2002 16:07:58 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <10d601c1f2ab$ee7b6c40$6501a8c0@multisofteducation.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Return-path: <owner-netdev@oss.sgi.com>
To: <netdev@oss.sgi.com>
List-Id: netdev.vger.kernel.org

Hi All,

I hope this is no intrusion to this list or that it is off-topic, however, I will try to keep it as much to the core ipv4 area as possible. If you do respond, please CC replies directly to me since I am not on the list.

First off, I'm working on a larger document which contains a reference to all ipv4 sysctl calls available in linux. The reference part of the document is heavily based upon linux/Documentation/networking/ip-sysctl.txt document written by various writers, as it looks now. The main problem is that I have quite a problem understanding the behaviours of some variables/sysctl calls, and what they do. 

I will (try to :-)) briefly sum up all questions I have at this moment below:

ip_nonlocal_bind - how does this affect the ip stack? How and why will it break certain applications (according to ip-sysctl.txt)? A possible scenario when it may be used?

INET peer storage - one of the subtopics from the ip-sysctl.txt. What does this refer to? ARP tables and storage I assume, but I am not 100% sure? Would anyone care to give a very very brief explanation to this "section" and why a specific subsection on this in the document, but not 

tcp_max_syn_backlog - I haven't looked in the source code for this one myself, but the default values listed in the ip-sysctl.txt document are faulty in comparison to the default values I get on my own systems. Are these calculated at boot time, or is the document simply old?

tcp_fack - Does this variable turn on Fast Acknowledgement, and if so, in which RFC is this documented? RFC 2018, 2883 or some other? 

tcp_reordering - What does it mean? How does it work? Is there any RFC documenting this and what the default behaviour should be? 

tcp_adv_win_scale - I can say nothing but "hmmm" about the explanation in the ip-sysctl.txt document, and I understand pretty much nothing from what I've read in the source, though I haven't even tried very much so far. What do the different equations do as specified in ip-sysctl.txt? What do the variables used in them mean? Perhaps I'm just dumb or something :-).

icmp_ratelimit
icmp_ratemask - Both these are interconnected afaik, but they are not listed in the ip-sysctl.txt (seems they override the old variables that where available). From what I understand, ratemask tells which ICMP types (and codes?) are specified, and if to ratelimit these. How is this mask calculated? How is the ratelimit set, and in what measurement?

Those are the questions I have for now.. Sorry for the massive amount of questions, but I have collected them for a week or so :-). I really really hope this is not offtopic for this list and that noone will get too annoyed over the questions and that someone is able to reply to them.

Have nice day,

Oskar Andreasson
http://www.boingworld.com
http://people.unix-fu.org/andreasson/
mailto: blueflux@koffein.net

PS. I will be gone over the weekend so there is no rush with any replies really, just thought I'd get them away before the list of questions grows too large. DS.
