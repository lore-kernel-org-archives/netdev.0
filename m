From: Paul Furness <paul.furness@vil.ite.mee.com>
Subject: NIS won't authenticate users
Date: 11 Apr 2002 16:58:16 +0100
Sender: linux-net-owner@vger.kernel.org
Message-ID: <1018540696.32508.16.camel@x2.vil.ite.mee.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-net-owner@vger.kernel.org>
To: linux-net@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, world.

Is there by any chance a NIS guru around who can make some suggestions
about a problem I have?

I have just built a linux workstation, and I want to join it to an
existing NIS domain for user authentication. 

Although it appears to bind correctly to the domain, and things like
ypwhich and getent produce exactly the results I want, it will not
accept a user's (correct) password. If I am on the box as root, and I su
- username, it works fine - so it obviously recognises the users. But if
I try and log in on the console as that user, I get an "Incorrect
Password" error.

Interestingly, if I telnet to the box from anywhere and try logging in
as a NIS user, it says "User account has expired" and closes the
connection.

I can log in fine a local user (this also works over telnet)

I thought it might be the version of ypbind, so I tried updating that to
3.3, with no effect. 

I know the existing domain is fine as all the other machines on the LAN
(about 50 or so) have no problems at all. I tried copying all the config
files that I think are important, but that didn't help either.

One possible caveat: I'm trying out the beta of RedHat 7.3, but I don't
think that's the problem - all the rest of the networking seems stable
enough.

I always thought I knew how to set up NIS, but this one is just not
working right!  

Anyone got any ideas?

BUNgle.

"If it ain't broke, hit it 'till it is, then you can fix it..."

