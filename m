From: cliff white <cliffw@osdl.org>
Subject: gcc confused about static inline. - route.c
Date: Mon, 28 Mar 2005 13:23:14 -0800
Message-ID: <20050328132314.480b8b1d@es175>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Building the gkernel bits, have this error:

net/ipv4/route.c: In function `rt_remove_balanced_route':
net/ipv4/route.c:151: sorry, unimplemented: inlining failed in call to 'compare_keys': function body not available
net/ipv4/route.c:540: sorry, unimplemented: called from here

route.c has this define at line 151
:
static inline int compare_keys(struct flowi *fl1, struct flowi *fl2);

function body is defined starting at line 861. 

We are using gcc 3.4.2 right now, is there a way to fix this?
thanks
cliffw

-- 
"Ive always gone through periods where I bolt upright at four in the morning; 
now at least theres a reason." -Michael Feldman
