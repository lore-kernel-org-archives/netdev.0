From: Martin Devera <devik@cdi.cz>
Subject: QoS _put, _get and _delete class ops semantic
Date: Tue, 9 Apr 2002 13:43:59 +0200 (CEST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.10.10204091332410.15162-100000@luxik.cdi.cz>
References: <Pine.GSO.4.30.0204072343250.12041-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
To: jamal <hadi@cyberus.ca>
In-Reply-To: <Pine.GSO.4.30.0204072343250.12041-100000@shell.cyberus.ca>
List-Id: netdev.vger.kernel.org

Hi Jamal,

please can you help me with this ? During testing of
speed improved HTB (as we talked about) I have problem
to understand rationale behing Subj and can't find any
docs.
put and get seem to be simply reference counting on
class object. I'd expect thet class creation will call
get once to assure that it is locked in active state and
"tc class del" would call last put to release this last
reference (and class will destroy itself).
Unfortunately there is delete class op which seems to do
almost the same as put.
Do you know rationale behind it ? Why we have both put
and delete and what tc framework expect from qdisc ?
I know there is some description tcio-current but it doesn't
go into great depth on this topic.

Thanks in advance,
devik
